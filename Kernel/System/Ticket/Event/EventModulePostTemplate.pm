# --
# Kernel/System/Ticket/Event/EventModulePostTemplate.pm - event module
# Copyright (C) 2001-2010 OTRS AG, http://otrs.org/
# --
# $Id: EventModulePostTemplate.pm,v 1.1 2010-05-10 17:56:20 sb Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Ticket::Event::EventModulePostTemplate;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.1 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (
        qw(
        ConfigObject CustomerGroupObject CustomerUserObject DBObject EncodeObject GroupObject
        HTMLUtilsObject LinkObject LockObject LogObject LoopProtectionObject MainObject
        PriorityObject QueueObject SendmailObject ServiceObject SLAObject StateObject
        TicketObject TimeObject TypeObject UserObject ValidObject
        )
        )
    {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(TicketID Event Config)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    return 1 if $Param{Event} ne 'TicketCreate';

    my %Ticket = $Self->{TicketObject}->TicketGet(
        TicketID => $Param{TicketID},
        UserID   => 1,
    );
    return 1 if !%Ticket;
    return 1 if $Ticket{State} eq 'Open';

    # do some stuff
    $Self->{TicketObject}->HistoryAdd(
        TicketID     => $Param{TicketID},
        CreateUserID => 1,
        HistoryType  => 'Misc',
        Name         => 'New ticket with state other than Open!',
    );

    return 1;
}

1;
